require 'csv'
require 'fileutils'

desc 'Export meeting minutes'
task :export do

  FileUtils.mkdir_p './tmp/export'
  CSV.open('./tmp/export/motions.csv', 'w') do |csv|

    csv << ['Date', 'Preamble', 'Moved By', 'Seconded By', 'Motion', 'In Favour', 'Against', 'Notes', 'Result' ]

    Dir.foreach('./minutes') do |file|
      next if file == '.' or file == '..'

      meeting = Meeting.from_file "./minutes/#{file}"

      meeting.motions.each do |motion|
        csv << [meeting.date, motion.preamble, motion.moved_by, motion.seconded_by, motion.text, motion.in_favour.join(','), motion.against.join(','), motion.notes, motion.result]
      end
    end
  end
end
