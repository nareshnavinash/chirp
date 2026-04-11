cask "chirp" do
  version "0.1.0"
  sha256 "" # TODO: fill after build

  url "https://github.com/chirpapp/chirp/releases/download/v#{version}/Chirp-#{version}-macos.dmg"
  name "Chirp"
  desc "Smart break reminders for healthy screen habits"
  homepage "https://chirpapp.dev"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "chirp_app.app", target: "Chirp.app"

  zap trash: [
    "~/Library/Preferences/com.chirpapp.chirp.plist",
    "~/Library/Application Support/com.chirpapp.chirp",
  ]
end
