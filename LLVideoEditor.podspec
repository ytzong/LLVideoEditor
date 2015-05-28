Pod::Spec.new do |s|
  s.name         = "LLVideEditor"
  s.version      = "1.0.0"
  s.summary      = "A very simple library to edit videos."
  s.description  = <<-DESC
                   LLVideoEditor is a library for rotating, cropping and adding layer to videos and finally exporting them as a new video.
                   DESC

  s.homepage     = "https://github.com/omergul123/LLVideEditor"
  s.license      = { :type => 'APACHE', :file => 'LICENSE' }
  s.author       = { "Ömer Faruk Gül" => "omer@omerfarukgul.com" }
  s.platform     = :ios,'7.0'
  s.source       = { :git => "https://github.com/omergul123/LLVideEditor.git", :tag => "v1.0.0" }
  s.source_files  = 'LLVideEditor/*.{h,m}'
  s.requires_arc = true
  s.framework = 'AVFoundation'
end
