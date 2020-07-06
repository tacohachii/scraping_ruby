require 'csv'

module CSVConvertible
  def to_csv(*keys)
    keys = self.map(&:keys).inject([], &:|) if keys.empty?
    CSV.generate do |csv|
      csv << keys
      self.each { |hash| csv << hash.values_at(*keys) }
    end
  end
end
