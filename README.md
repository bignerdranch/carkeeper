# carkeeper

Sample code accompanying @lyricsboy's talk "Applying the Single Responsibility Principle in iOS"

## CarKeeper-iOS

The iOS app is stored in CarKeeper-iOS. It is based on the "Master/Detail" application template from Xcode.
Check out the commit history to see how various changes were applied to better conform to the SRP.

## carkeeper-rails

The companion Ruby on Rails app lives in the carkeeper-rails directory. Assuming you have a modern Rails environment,
get the app up and running like this:

    carkeeper-rails$ bundle install
    carkeeper-rails$ rake db:migrate
    carkeeper-rails$ rails s

Then you can visit http://localhost:3000 and create some cars to populate the database with. The iOS app uses a 
hard-coded URL pointing to `http://localhost:3000/cars.json`, so if you use a different port or whatever, you need
to change that.