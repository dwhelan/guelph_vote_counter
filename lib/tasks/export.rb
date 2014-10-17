require 'csv'

desc 'Export meetings'
task :export do

  meeting = Meeting.from_url 'http://guelph.ca/wp-content/uploads/council_minutes_082514.pdf'

  CSV.open('tmp/motions.csv', 'w') do |csv|

    csv << ['Date', 'Preamble', 'Moved By', 'Seconded By', 'Motion', 'In Favour', 'Against', 'Notes', 'Result' ]
    meeting.motions.each do |motion|
      csv << [meeting.date, motion.preamble, motion.moved_by, motion.seconded_by, motion.text, motion.in_favour.join(','), motion.against.join(','), motion.notes, motion.result]
    end
  end
end
