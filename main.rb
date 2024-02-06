# frozen_string_literal: true

require 'octokit'
require 'yaml'
require 'irb'

require_relative 'lib/teams'
require_relative 'lib/team_repo_permissions'

unless ENV.key?('GH_PAT')
  puts 'Please provide a valid GitHub Personal Access Token in the GH_PAT environment variable.'
  exit 1
end

unless ENV.key?('GH_ORG')
  puts 'Please provide an organization name in the GH_ORG environment variable.'
  exit 1
end

unless File.exist?('teams.yml')
  puts 'Please provide a valid teams.yml file in the current directory.'
  exit 1
end

puts "Examining the #{ENV['GH_ORG']} organization..."

puts "Starting..."

client = Octokit::Client.new(access_token: ENV['GH_PAT'])
client.auto_paginate = true

# List all teams in the current organization
# Map them to the reams in the teams.yml file
# Warn if teams in the teams.yml file do not exist in the organization

# Check if the team has access to the repository
# If not, add the team to the repository
# Optionally clean teams not assigned via topics

# Load team mapping from teams.yml file
teams = Teams.new('teams.yml')

# binding.irb

# List all teams in the current organization
client.organization_teams(ENV['GH_ORG'])

# Fetch all repositories in the organization
all_repos = client.organization_repositories(ENV['GH_ORG'])

# Filter repositories with topics that match the prefix value in the teams.yml file
repos_with_topics = all_repos.select { |repo| repo[:topics].any? { |topic| topic.start_with?(teams.prefix) } }

repos_with_topics.each do |repo|
  puts "Evaluating #{repo.full_name}..."
  repo_teams = client.repository_teams(repo.full_name)
  repo_team_topics = teams.filter_repo_topics(repo[:topics])

  repo_teams.each do |team|
    if teams.exists?(team[:slug])
      if teams.permission(team[:slug]) != team[:permission]
        # Update teams with incorect permissions
        puts "\t#{team[:name]} (#{team[:slug]}) has the wrong permission level for #{repo.full_name} (expected #{teams.permission(team[:slug])}, got #{team[:permission]})"

        client.update_repo_team_permissions(
          ENV['GH_ORG'],
          team[:slug],
          repo,
          { permission: teams.permission(team[:slug]) }
        )

      else
        puts "\t#{team[:name]} (#{team[:slug]}) has correct permissions for #{repo.full_name}."
        repo_team_topics.delete(teams.topic(team[:slug]))
      end

    else
      puts "\t#{team[:name]} (#{team[:slug]}) has access to #{repo.full_name}, but is not the teams.yml file."
      # TODO: Optionally remove team from repository
    end
  end

  repo_team_topics.each do |topic|

    next if teams.from_topic(topic).nil?

    # Add team to repository
    puts "Adding #{teams.from_topic(topic)} to #{repo.full_name} with #{teams.permission(topic)} permission."

    client.update_repo_team_permissions(
      ENV['GH_ORG'],
      teams.from_topic(topic),
      repo,
      { permission: teams.permission(topic) }
    )
  end
end

puts "Done."