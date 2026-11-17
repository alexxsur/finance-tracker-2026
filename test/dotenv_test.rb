require "test_helper"
require "fileutils"
require "open3"
require "tmpdir"

class DotenvTest < ActiveSupport::TestCase
  test "Rails loads .env without overriding exported variables" do
    Dir.mktmpdir("finance-tracker-dotenv") do |dir|
      %w[bin config].each { |path| FileUtils.cp_r(Rails.root.join(path), dir) }
      %w[app db lib Gemfile Gemfile.lock].each do |path|
        FileUtils.ln_s(Rails.root.join(path), File.join(dir, path))
      end
      File.write(File.join(dir, ".env"), "SEED_USER_PASSWORD=example-from-file\nDOTENV_PRECEDENCE_CHECK=from-file\n")
      env = {
        "RAILS_ENV" => "test",
        "BUNDLE_GEMFILE" => File.join(dir, "Gemfile"),
        "SEED_USER_PASSWORD" => nil,
        "DOTENV_PRECEDENCE_CHECK" => "from-shell"
      }
      script = 'abort "dotenv loading failed" unless ENV["SEED_USER_PASSWORD"] == "example-from-file" && ENV["DOTENV_PRECEDENCE_CHECK"] == "from-shell"'
      output, status = Open3.capture2e(env, File.join(dir, "bin/rails"), "runner", script, chdir: dir)

      assert status.success?, output
    end
  end
end
