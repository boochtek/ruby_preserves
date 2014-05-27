# NOTE: For this file to work, your ~/.irbrc file must contain snippet from http://www.samuelmullen.com/2010/04/irb-global-local-irbrc/.


# Allow reloading our gem.
def reload!
  @gem_name = Dir["#{Dir.pwd}/*.gemspec"].first.split('/').last.sub('.gemspec', '')
  files = $LOADED_FEATURES.select { |feat| feat =~ %r[/#{@gem_name}/] }
  files.each { |file| load file }
end
