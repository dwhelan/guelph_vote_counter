# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', all_on_start: false, all_after_pass: false, zeus: true, parallel: false, bundler: false, notification: true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
end
