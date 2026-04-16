platform :ios, '__DEPLOYMENT_TARGET__'

install! 'cocoapods',
         :deterministic_uuids => false

target '__APP_NAME__' do
  project '__APP_NAME__.xcodeproj'
  use_frameworks! :linkage => :static

  pod 'OCAppBox', :path => '__OCAPPBOX_POD_PATH__'
end
