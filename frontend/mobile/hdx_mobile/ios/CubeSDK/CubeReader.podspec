Pod::Spec.new do |s|
  s.name         = 'CubeReader'
  s.version      = '1.3.0'
  s.summary      = 'Local wrapper for the BIOSYNEX CubeReader SDK (SDK itself is not in git).'
  s.description  = 'Wraps CubeReader.xcframework and the Cube license/config assets placed in this folder. Neither is committed to the repository.'
  s.homepage     = 'https://www.biosynex.com'
  s.license      = { :type => 'Proprietary', :text => 'Proprietary BIOSYNEX SDK. Not redistributable.' }
  s.author       = 'BIOSYNEX'
  s.source       = { :path => '.' }
  s.platform     = :ios, '17.0'
  s.vendored_frameworks = 'CubeReader.xcframework'
  s.resources    = 'assets/*.{dat,bin}'
end
