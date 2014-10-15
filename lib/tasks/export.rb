require 'csv'

desc 'Export meetings'
task :export do

  meeting = Meeting.new 'http://guelph.ca/wp-content/uploads/council_minutes_082514.pdf'

  CSV.open('tmp/motions.csv', 'w') do |csv|

    csv << ['Date', 'Motion', 'In Favour', 'Against', 'Notes', 'Result' ]
    meeting.motions.each do |motion|
      csv << [meeting.date, motion.text, motion.in_favour.join(','), motion.against.join(','), motion.notes, motion.result]
    end
  end

end
