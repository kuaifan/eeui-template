

Pod::Spec.new do |s|



  s.name         = "eeui"
  s.version      = "2.3.11"
  s.summary      = "eeui plugin."
  s.description  = <<-DESC
                    eeui plugin.
                   DESC

  s.homepage     = "https://eeui.app"
  s.license      = "MIT"
  s.author             = { "kuaifan" => "aipaw@live.cn" }
  s.source =  { :path => '.' }
  s.source_files  = "eeui", "**/**/*.{h,m,mm,c}"
  s.exclude_files = "Source/Exclude"
  s.resources = ['eeui/Source/*.*',
                  'eeui/Utility/CCNScan/CodeScan.bundle',
                  'eeui/Utility/MJRefresh/MJRefresh.bundle',
                  'eeui/Utility/IQKeyboardManager/Resources/IQKeyboardManager.bundle']
  s.prefix_header_file = 'eeui/Utility/PrefixHeader.pch'
  s.platform     = :ios, "8.0"
  s.requires_arc = true

  s.dependency 'WeexSDK'
  s.dependency 'WeexPluginLoader', '~> 0.0.1.9.1'

end
