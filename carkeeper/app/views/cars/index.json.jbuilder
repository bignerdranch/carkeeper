json.array!(@cars) do |car|
  json.extract! car, :id, :nickname, :make, :model, :rgb_color, :year
  json.url car_url(car, format: :json)
end
