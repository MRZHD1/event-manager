require 'csv'
require 'google/apis/civicinfo_v2'

$civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
$civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end
def find_legislators(zipcode)
  begin
    legislators = $civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials
    legislator_names = legislators.map(&:name).join(", ")
    return legislator_names
  rescue 
    return 'Unknown'
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])
  legislators = find_legislators(zipcode)

  puts "#{name} #{zipcode} #{legislators}"
end