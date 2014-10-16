guard 'rspec', all_on_start: false, all_after_pass: false, parallel: false, notification: true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/counter/(.+)\.rb$})  { |m| "spec/#{m[1]}_spec.rb" }
end
