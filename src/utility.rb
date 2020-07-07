require 'open-uri'
require 'nokogiri'
require 'mechanize'

def get_company_info_hash_arr(root_url, index_path, page_range)
  company_info_hash_arr = []
  for page in page_range do
    puts page
    charset = nil

    target_url = root_url + index_path + page.to_s
    html = open(target_url) do |f|
      charset = f.charset
      f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)
    doc.search('br').each { |n| n.replace("\n") }

    # 名前とURL
    company_name_arr = []
    company_url_arr = []
    doc.xpath('//h1[@class="p-corporate__name"]').each do |node|
      company_path = node.children.attribute('href').value
      company_url = root_url + company_path
      company_name = node.children.children.inner_text
      company_name_arr << company_name
      company_url_arr << company_url
    end

    raise "invalid company_url_arr" if company_name_arr.count != company_url_arr.count

    # 調達額
    found_amount_arr = []
    doc.css('.p-foundAmount__value').each do |node|
      found_amount = node.children.inner_text == "-" ? "0" : node.children.inner_text
      found_amount_arr << found_amount
    end
    raise "invalid found_amount_arr" if company_name_arr.count != found_amount_arr.count

    # 設立年月
    establish_arr = []
    doc.css('.p-establishment__value').each do |node|
      establish = node.children.inner_text
      establish_arr << establish
    end
    raise "invalid establish_arr" if company_name_arr.count != establish_arr.count

    # カテゴリ
    categories_arr = []
    doc.css('.p-category').each do |node|
      categories = []
      node.children.each do |child|
        category = child.children.inner_text
        categories << category if category != ""
      end
      categories_arr  << categories
    end
    raise "invalid categories_arr" if company_name_arr.count != categories_arr.count

    # hashにまとめる
    company_name_arr.each_with_index do |company_name, i|
      company_info_hash = {
          company_name: company_name,
          url: company_url_arr[i],
          found_amount: found_amount_arr[i],
          establish: establish_arr[i],
          categories: categories_arr[i]

      }
      company_info_hash_arr << company_info_hash
    end
  end

  return company_info_hash_arr
end


def get_complete_company_hash_arr(company_info_hash_arr)
  agent = Mechanize.new
  agent.user_agent_alias = "Windows Mozilla"
  agent.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36"

  puts ""
  puts "company num #{company_info_hash_arr.length}"
  puts "====================="
  complete_company_hash_arr = []
  company_info_hash_arr.each_with_index do |company_info, i|

    if company_info[:url] == "https://startup-db.com/ja/companies/16043/x.ai"
      page = agent.get("https://startup-db.com/ja/companies/16043")
    else
      page = agent.get(company_info[:url])
    end

    # Nokogiriを使った操作
    company_info[:adress] = "-"
    company_info[:homepage] = "-"
    company_info[:employee_num] = "-"
    page.search(".p-col__label").each do |label|
      label_text = label.inner_text #=> imgタグの一覧
      if label_text == "住所"
        unless label.next.nil?
          unless label.next.next.nil?
            company_info[:adress] = label.next.next.inner_text.strip
          end
        end
      elsif label_text == "企業ホームページ・SNS"
        unless label.next.nil?
          unless label.next.next.nil?
            company_info[:homepage] = label.next.next.inner_text.strip
          end
        end
      elsif label_text == "従業員数"
        unless label.next.nil?
          unless label.next.next.nil?
            company_info[:employee_num] = label.next.next.inner_text.strip
          end
        end
      end
    end
    company_info[:description] = page.at(".p-intro__description") ? page.at(".p-intro__description").inner_text : "-"
    puts "#{i+1}：#{company_info[:company_name]}"
    puts "====================="
    complete_company_hash_arr << company_info
  end
end
