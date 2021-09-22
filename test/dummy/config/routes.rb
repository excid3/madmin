Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "home#index"

  if Gem.loaded_specs["rails"].version >= Gem::Version.new(6.1)
    draw(:madmin)
  else
    route_path = "#{Rails.root}/config/routes/madmin.rb"
    instance_eval(File.read(route_path), route_path.to_s)
  end
end
