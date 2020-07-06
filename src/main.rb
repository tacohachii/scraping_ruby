# 実行
# ruby src/main.rb

require 'benchmark'
require 'fileutils'
require './src/utility'
require './src/csv_module'

# 定義
ROOT_URL = "https://startup-db.com"
index_path = "/ja/companies?&p="
page_range = 1..1 # ここは適宜変更する
t = Time.new
time = t.strftime("%Y_%m_%d_%H_%M_%S")

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
  IO.write "output/output_#{time}.csv", outputs.to_csv
  puts ""
end
puts "処理時間：#{result.floor}s"
puts "出力：output/output_#{time}.csv"
FileUtils.rm("output/tmp_output.csv")
