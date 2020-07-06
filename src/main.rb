# 実行
# ruby src/main.rb

require 'benchmark'
require 'fileutils'
require './src/utility'
require './src/csv_module'

raise "引数の数が間違っています" unless ARGV.size() == 2

# 定義
ROOT_URL = "https://startup-db.com"
index_path = "/ja/companies?&p="
page_min = ARGV[0] 
page_max = ARGV[1] # 2020/7/6 現在最新 617
page_range = page_min..page_max 
t = Time.new
time = t.strftime("%Y_%m_%d_%H_%M_%S")
puts "====================="

# 実行時間を測定
result = Benchmark.realtime do
  # 1層目で取れる情報を取得
  company_info_hash_arr = get_company_info_hash_arr(ROOT_URL, index_path, page_range)
  outputs = company_info_hash_arr.extend(CSVConvertible)
  IO.write 'output/tmp_output.csv', outputs.to_csv
  puts "====================="
  
  # 社別ページでの情報を取得
  complete_company_hash_arr = get_complete_company_hash_arr(company_info_hash_arr)
  outputs = complete_company_hash_arr.extend(CSVConvertible)
  IO.write "output/output_#{page_min}_#{page_max}__#{time}.csv", outputs.to_csv
  puts ""
end
puts "処理時間：#{result.floor}s"
puts "出力：output/output_#{page_min}_#{page_max}__#{time}.csv"
FileUtils.rm("output/tmp_output.csv")
