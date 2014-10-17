require 'json'

desc 'Import meeting minutes'
task :import do

  affinity = Affinity.new
  affinity.add_group %w(Farbridge Laidlaw Hofland Findlay Piper Wettstein Dennis)
  affinity.add_group ['Guthrie', 'Bell', 'Furfaro', 'Van Hellemond']

  meeting_count = 0

  Dir.foreach('./minutes') do |file|
    next if file == '.' or file == '..'

    meeting_count = meeting_count + 1
    meeting = Meeting.from_file "./minutes/#{file}"
    meeting.motions.select(&:contested?).each do |motion|
      affinity.add(motion.in_favour)
      affinity.add(motion.against)
    end
  end

  File.open('./views/affinity/data.json', 'w') do |file|
    file.write affinity.force_field(min: meeting_count*2).to_json
  end

end
