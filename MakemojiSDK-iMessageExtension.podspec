Pod::Spec.new do |s|
  s.name             = 'MakemojiSDK-iMessageExtension'
  s.version          = '1.0.11'
  s.summary          = "A free emoji iMessage extension"
  s.description      = <<-DESC
                       By installing our iMessage SDK every user of your app will instantly have access to new and trending emojis.  Our goal is to increase user engagement as well as provide actionable real time data on sentiment (how users feel) and affinity (what users like). With this extensive data collection your per-user & company valuation will increase along with your user-base.
                       DESC
                       
  s.homepage         = 'http://makemoji.com'
  s.license      	 = { :type => 'Commercial' }
  s.author           = { 'Makemoji' => 'contact@makemoji.com' }
  s.source           = { :git => 'https://github.com/makemoji/MakemojiSDK-iMessageExtension.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '10.0'
  s.source_files = 'MakemojiSDK-iMessageExtension/Classes/**/*'
  s.frameworks = 'Foundation', 'SystemConfiguration', 'UIKit', 'Messages', 'AdSupport'
  s.dependency 'AFNetworking', '>= 2.6.3'
  s.dependency 'SDWebImage', '>= 4.0'
  s.requires_arc = true
  s.resource_bundles = {
  	'MakemojiSDK-iMessageExtension' => ['MakemojiSDK-iMessageExtension/Assets/*']
  }  
end
