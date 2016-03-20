puts "This is a sample application..."
sleep 10
puts "Woke up."

run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["ppid:#{Process.ppid}\n"]] }
