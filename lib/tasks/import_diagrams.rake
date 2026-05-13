require "net/http"
require "json"

namespace :diagrams do
  desc "Fetch and upsert matchup diagrams from Buckler API. Usage: rake diagrams:import[202603]"
  task :import, [ :season ] => :environment do |_, args|
    season = args[:season] || Time.current.strftime("%Y%m")
    puts "Importing diagrams for season: #{season}"

    name_to_code = Card::CHARACTER_NAMES.invert

    headers = {
      "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
      "Referer" => "https://www.streetfighter.com/6/buckler/ja-jp/stats/dia_master",
      "Accept" => "application/json"
    }

    dia_ranks = {
      "1" => "Rookie", "2" => "Iron", "3" => "Bronze",
      "4" => "Silver", "5" => "Gold", "6" => "Platinum", "7" => "Diamond"
    }

    dia_master_ranks = {
      "36" => "Master", "40" => "High Master",
      "41" => "Grand Master", "42" => "Ultimate Master"
    }

    fetch = ->(url) {
      uri = URI(url)
      req = Net::HTTP::Get.new(uri)
      headers.each { |k, v| req[k] = v }
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
      raise "HTTP #{res.code}: #{url}" unless res.code == "200"
      JSON.parse(res.body)
    }

    build_records = ->(data, rank_map) {
      records = []
      now = Time.current
      c_sort = data["diaData"]["c"]["ci_sort"]

      rank_map.each do |rank_key, rank_name|
        next unless c_sort[rank_key]

        rank_data = c_sort[rank_key]
        opponent_map = rank_data["opponent_header"].each_with_object({}) { |h, m| m[h["id"]] = h["name_alpha"] }

        rank_data["records"].each do |record|
          char_code = name_to_code[record["name_alpha"]]
          next unless char_code

          record["values"].each do |v|
            next if v["val"].nil? || v["val"].in?([ "-", "-.---", "" ])

            opp_name = opponent_map[v["_oid"]]
            next unless opp_name

            opp_code = name_to_code[opp_name]
            next unless opp_code

            records << {
              rank: rank_name,
              character_code: char_code,
              enemy_code: opp_code,
              win_rate: v["val"].to_f,
              season: season,
              created_at: now,
              updated_at: now
            }
          end
        end
      end

      records
    }

    upsert = ->(records, label) {
      return puts "  #{label}: スキップ（データなし）" if records.empty?
      MatchupDiagram.upsert_all(
        records,
        unique_by: [ :character_code, :enemy_code, :rank ],
        update_only: [ :win_rate, :season ]
      )
      puts "  #{label}: #{records.size}件 upsert完了"
    }

    begin
      puts "Fetching dia (Rookie〜Diamond)..."
      dia_data = fetch.call("https://www.streetfighter.com/6/buckler/api/ja-jp/stats/dia/#{season}")
      upsert.call(build_records.call(dia_data, dia_ranks), "dia")

      puts "Fetching dia_master (Master〜Ultimate Master)..."
      master_data = fetch.call("https://www.streetfighter.com/6/buckler/api/ja-jp/stats/dia_master/#{season}")
      upsert.call(build_records.call(master_data, dia_master_ranks), "dia_master")

      puts "完了"
    rescue => e
      puts "エラー: #{e.message}"
      raise e
    end
  end
end
