require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(number)
  number = number.to_s.delete("^0-9") #Removes non-digits
  if number.length == 10 || (number.length == 11 && number[0] == '1')
    return number[-10..-1] #Returns last 10 digits
  else
    return ''
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

time_frequency = Hash.new(0)
weekday_frequency = Hash.new(0)

contents.each do |row|
  format_date = row[:regdate].split(" ")

  time = Time.parse(format_date[1])
  time_frequency[time.hour] += 1

  date = Date.parse(format_date[0][-2..-1] + '/' + format_date[0][..-4])
  weekday_frequency[date.wday] += 1

  id = row[0]
  name = row[:first_name]
  number = clean_phone(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end


time_frequency # This is the peak hours for signups
weekday_frequency # This is the peak days of the week for signups