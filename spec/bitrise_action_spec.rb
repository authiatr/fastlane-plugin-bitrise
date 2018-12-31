describe Fastlane::Actions::BitriseAction do
  describe '#get_environments_from' do
    it 'should return a valid environments array' do
      parameters = {
        "VAR_1" => "TEST_1",
        "VAR_2" => "TEST_2"
      }
      result = Fastlane::Actions::BitriseAction.get_environments_from(parameters).to_json

      expect(result).to eq("[{\"mapped_to\":\"VAR_1\",\"value\":\"TEST_1\",\"is_expand\":true},{\"mapped_to\":\"VAR_2\",\"value\":\"TEST_2\",\"is_expand\":true}]")
    end
  end

  describe '#get_post_payload' do
    it 'should return a valid json payload' do
      # get_post_payload(trigger_token, workflow, build_message, branch, commit, tag, environments)
      trigger_token = "YOUR_TRIGGER_TOKEN"
      workflow = "Beta"
      build_message = "Deploy build version 1.3.2 build number 11 to Beta test"
      branch = "release/1.3.2"
      commit = "ca82a6dff817ec66f44342007202690a93763949"
      tag = "ios-v1.3.2-11"
      author = "Developer"
      environments = {
        "BUILD_CONFIGURATION" => "Production",
        "ANOTHER_ENVIRONMENT_VARIABLE" => "123456"
      }

      result = Fastlane::Actions::BitriseAction.get_post_payload(trigger_token,
                                                                 workflow,
                                                                 author,
                                                                 build_message,
                                                                 branch,
                                                                 commit,
                                                                 tag,
                                                                 environments)

      expected_payload = "{\"payload\":{\"hook_info\":{\"type\":\"bitrise\",\"build_trigger_token\":\"YOUR_TRIGGER_TOKEN\"},\"triggered_by\":\"Developer\",\"build_params\":{\"workflow_id\":\"Beta\",\"commit_message\":\"Deploy build version 1.3.2 build number 11 to Beta test\",\"branch\":\"release/1.3.2\",\"commit_hash\":\"ca82a6dff817ec66f44342007202690a93763949\",\"tag\":\"ios-v1.3.2-11\",\"environments\":[{\"mapped_to\":\"BUILD_CONFIGURATION\",\"value\":\"Production\",\"is_expand\":true},{\"mapped_to\":\"ANOTHER_ENVIRONMENT_VARIABLE\",\"value\":\"123456\",\"is_expand\":true}]}}}"
      expect(result).to eq(expected_payload)
    end
  end
end
