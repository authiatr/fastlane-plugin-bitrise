require 'fastlane/action'
require_relative '../helper/bitrise_helper'

module Fastlane
  module Actions
    class BitriseAction < Action
      def self.run(params)
        FastlaneCore::PrintTable.print_values(config: params.values(ask: false),
                                              hide_keys: [],
                                              title: "Bitrise options")

        json = get_post_payload(params[:trigger_token],
                                params[:workflow],
                                params[:author],
                                params[:build_message],
                                params[:branch],
                                params[:commit],
                                params[:tag],
                                params[:environments])

        trigger_bitrise_build(params[:app_slug], json)
      end

      # Get POST payload json
      #
      # Parameters:
      # - trigger_token: Bitrise.io trigger token
      # - workflow: Bitrise.io workflow to trigger (optional)
      # - author: Describe who triggered the build
      # - build_message: Build message on Bitrise.io (optional)
      # - branch: Git branch to trigger (optional)
      # - commit: Git commit to trigger (optional)
      # - tag: Git tag to trigger (optional)
      # - environments: Environments variables hash to replace (optional)
      #
      # Returns the JSON post payload
      def self.get_post_payload(trigger_token, workflow, author, build_message, branch, commit, tag, environments)
        UI.message("Payload creation...")
        json_curl = {}
        payload = {}

        hook_info = {}
        hook_info["type"] = "bitrise"
        hook_info["build_trigger_token"] = trigger_token
        payload["hook_info"] = hook_info

        unless author.nil?
          payload["triggered_by"] = author
        end

        build_params = {}
        unless workflow.nil?
          build_params["workflow_id"] = workflow
        end

        unless build_message.nil? || build_message.empty?
          build_params["commit_message"] = build_message
        end

        unless branch.nil?
          build_params["branch"] = branch
        end

        unless commit.nil?
          build_params["commit_hash"] = commit
        end

        unless tag.nil?
          build_params["tag"] = tag
        end

        unless environments.nil?
          build_params["environments"] = get_environments_from(environments)
        end
        payload["build_params"] = build_params
        json_curl["payload"] = payload

        json_curl.to_json
      end

      # Transform environments variable hash into dictionary objects
      #
      # Parameters:
      # - params: Environments hash to transform
      #
      # Returns the environments objects array
      def self.get_environments_from(params)
        environments = []

        params.each do |key, value|
          environment = {}
          environment["mapped_to"] = key
          environment["value"] = value
          environment["is_expand"] = true

          environments.push(environment)
        end

        environments
      end

      # Call the Bitrise.io API with a POST HTTP request with the specified payload.
      # It'll throw an exception if the API return an other HTTP status code than 201.
      #
      # Parameters:
      # - app_slug: Application slug
      # - json: request payload
      def self.trigger_bitrise_build(app_slug, json)
        UI.command(json)

        UI.message("Requesting Bitrise.io API...")
        uri = URI.parse("https://app.bitrise.io/app/#{app_slug}/build/start.json")
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
        request.body = json
        response = https.request(request)
        json_response = JSON.parse(response.body)
        FastlaneCore::PrintTable.print_values(config: json_response,
                                              hide_keys: [],
                                              title: "Bitrise API response")

        if response.code == "201"
          UI.success("Build triggered successfully on Bitrise.io 🚀")
        else
          if response.code == "400"
            error = json_response["message"]
          else
            error = json_response["error_msg"]
          end
          UI.user_error!("Couln't trigger the build on Bitrise.io. #{error}")
        end

        build_infos = {}
        build_infos["build_number"] = json_response["build_number"]
        build_infos["build_url"] = json_response["build_url"]

        build_infos
      end

      def self.description
        "Trigger a bitrise build"
      end

      def self.authors
        ["Robin AUTHIAT"]
      end

      def self.return_value
        "If the build could be triggered, it returns the build informations such as the bitrise build number and the bitrise build url in a Hash"
      end

      def self.details
        "This plugin allow you to trigger a specific Bitrise workflow with some arguments with a HTTPS POST on the Bitrise API."
      end

      def self.available_options
        [
          # App specific parameters
          FastlaneCore::ConfigItem.new(key: :app_slug,
                                  env_name: "BITRISE_APP_SLUG",
                               description: "Bitrise application slug, avalaible on bitrise.io > your app > code",
                                  optional: false,
                                      type: String,
                              verify_block: proc do |value|
                                              UI.user_error!("No Bitrise app slug given, pass it using `app_slug` parameter to the bitrise plugin.") unless value && !value.empty?
                                            end),
          FastlaneCore::ConfigItem.new(key: :trigger_token,
                                  env_name: "BITRISE_TRIGGER_TOKEN",
                               description: "Bitrise build trigger token, avalaible on bitrise.io > your app > code",
                                  optional: false,
                                      type: String,
                              verify_block: proc do |value|
                                              UI.user_error!("No Bitrise trigger token given, pass it using `trigger_token` parameter to the bitrise plugin.") unless value && !value.empty?
                                            end),
          # Bitrise.io specific parameters
          FastlaneCore::ConfigItem.new(key: :workflow,
                                  env_name: "BITRISE_WORKFLOW",
                               description: "Bitrise workflow to trigger, if not specified, it'll trigger the default one",
                                  optional: true,
                                      type: String,
                              verify_block: proc do |value|
                                              UI.user_error!("Empty Bitrise workflow given, pass it using `workflow` parameter to the bitrise plugin.") unless value && !value.empty?
                                            end),
          FastlaneCore::ConfigItem.new(key: :build_message,
                                  env_name: "BITRISE_BUILD_MESSAGE",
                               description: "Build message who'll appear on Bitrise.io build",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :author,
                                  env_name: "BITRISE_AUTHOR",
                               description: "Desribe who triggered the build it'll appear on Bitrise.io build",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :environments,
                                  env_name: "BITRISE_ENVIRONMENTS",
                               description: "Bitrise environments to replace, it'll override the previous environment variables specified. The Hash key has to be the environment variable key (without the $), the Hash value has to be environment variable value",
                                  optional: true,
                                      type: Hash,
                              verify_block: proc do |value|
                                              value.each do |key|
                                                UI.user_error!("Please remove the '$' from the environment variable #{key}") if key.to_s.include?("$")
                                              end
                                            end),
          # Git related parameters
          FastlaneCore::ConfigItem.new(key: :branch,
                                  env_name: "BITRISE_GIT_BRANCH",
                               description: "Git branch where to trigger bitrise workflow",
                                  optional: true,
                                      type: String,
                              verify_block: proc do |value|
                                              UI.user_error!("Empty Bitrise git branch given, pass it using `branch` parameter to the bitrise plugin.") unless value && !value.empty?
                                            end),
          FastlaneCore::ConfigItem.new(key: :commit,
                                  env_name: "BITRISE_GIT_COMMIT",
                               description: "Specific Git commit to trigger bitrise workflow",
                                  optional: true,
                                      type: String,
                              verify_block: proc do |value|
                                              UI.user_error!("Empty Bitrise git commit given, pass it using `commit` parameter to the bitrise plugin.") unless value && !value.empty?
                                            end),
          FastlaneCore::ConfigItem.new(key: :tag,
                                  env_name: "BITRISE_GIT_TAG",
                               description: "Specific Git tag to trigger bitrise workflow",
                                  optional: true,
                                      type: String,
                              verify_block: proc do |value|
                                              UI.user_error!("Empty Bitrise git tag given, pass it using `tag` parameter to the bitrise plugin.") unless value && !value.empty?
                                            end)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
