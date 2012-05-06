require 'test_helper'

module ManybotsTwitter
  class TwitterControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
  
  end
end
