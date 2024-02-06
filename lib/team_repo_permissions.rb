# frozen_string_literal: true

module Octokit
  class Client
    module RepoPermissionsMonkeypatch
      def update_repo_team_permissions(org, team_slug, repo, options = {})
        put "#{Organization.path org}/teams/#{team_slug}/repos/#{repo.owner[:login]}/#{repo.name}", options
      end
    end

    include Octokit::Client::RepoPermissionsMonkeypatch
  end
end
