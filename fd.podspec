Pod::Spec.new do |s|
  s.name = 'fd'
  s.version = '0.1.0'
  s.summary = 'Swift file descriptor / socket library'
  s.homepage = 'https://fuller.li/'
  s.license = { :type => 'BSD', :file => 'LICENSE' }
  s.author = { 'Kyle Fuller' => 'kyle@fuller.li' }
  s.social_media_url = 'http://twitter.com/kylefuller'
  s.source = { :git => 'https://github.com/kylef/fd.git', :tag => s.version }
  s.source_files = 'Sources/*.swift'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
end