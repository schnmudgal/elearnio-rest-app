# README

* Ruby version - 3.0.3
* Rails version - 6.1.7.6

### Dependencies
- Database - Postresql (14.8 used during development)

### Configuration
- Get `master.key` from authorized personnel before running the project. Save it under `/config` directory.
- Update `database.yml` as per your database credentials

### Install gems
- `bundle install`

### Database creation
- `rails db:setup` (it will use schema.rb file. If you want to do it separately - use the commands below)
- `rails db:create`
- `rails db:migrate`
- `rails db:seed`

### Access application
- Go to the project directory and run `rails server` or `rails s`
- Access endpoints using Chrome browser or Postman or insomnia etc.
- You may use `/elearnio.postman_collection.json` file to import endpoints directly to Postman

### How to run the test suite
- Suit - Rspec
- Command - `rspec specs/` (or [path/to/spec/directory])
- Check coverage - `open coverage/index.html`

## Development details
- Command used to create the application
  - `rails _6.1.7.6_ new elearnio-rest-app --database=postgresql --api`
  - Because I had default rails 7.x installed on my system, I had to use specific command to use rails 6 for the new project (as asked in coding challenge document).
  - `--api` flag is used to make the project very lightweight because as per the document only APIs are needed and no frontend is needed.
  - `--database=postgresql` flag to select Postgresql database integration to begin with as per the requirement of the coding challenge

## Some salient features of the project:
- Created an API only application of Rails to lightweight the app.
- Single table "users" is used for both Talent as well as Author resources by using simple Ruby inheritance.
- Join tables are used for 1:M relationships.
- Comments are added at relevant places for better explanation.
- Seed data is added in "seeds.rb" file.

- Models
  - Concern: ProgressStatusActionable is used to reuse progress_status functionalties.
  - 3 models used inheritance like "Author < User", "Talent < User"; and used same "users" table.

- Controllers
  - Namespaced controllers used for the APIs as per the common standards like "api/v1/".
  - "render_success_response" and "render_failure_reponse" are added at "Api::V1::BaseController" to standardise common responses.
  - json responses are customised using "inlcude", "only" options.

- Services
  - Service: LearningPathService is created for "add_courses" and "remove_courses".

- Routes
  - Normal namespaces and resources are used.
  - Custom member/collection methods are added to relevant resources.

- Test
  - Rspecs are used
  - Models and Controllers specs are added
  - "shoulda-matchers", "factory_bot_rails", "faker", and "simplecov" gems are used to assist in testing.
  - "/elearnio.postman_collection.json" collection is added to the project which can be used to directly import postman collections.

- Gems
  - "annotate" gem is used to annotate db-fields in models itself.
  - "acts_as_list" gem is used to manage the list of chilren "learning_paths_talents" for a "learning_path".
