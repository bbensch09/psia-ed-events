require 'test_helper'

class PrimaryLocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @primary_location = primary_locations(:one)
  end

  test "should get index" do
    get primary_locations_url
    assert_response :success
  end

  test "should get new" do
    get new_primary_location_url
    assert_response :success
  end

  test "should create primary_location" do
    assert_difference('PrimaryLocation.count') do
      post primary_locations_url, params: { primary_location: { name: @primary_location.name } }
    end

    assert_redirected_to primary_location_url(PrimaryLocation.last)
  end

  test "should show primary_location" do
    get primary_location_url(@primary_location)
    assert_response :success
  end

  test "should get edit" do
    get edit_primary_location_url(@primary_location)
    assert_response :success
  end

  test "should update primary_location" do
    patch primary_location_url(@primary_location), params: { primary_location: { name: @primary_location.name } }
    assert_redirected_to primary_location_url(@primary_location)
  end

  test "should destroy primary_location" do
    assert_difference('PrimaryLocation.count', -1) do
      delete primary_location_url(@primary_location)
    end

    assert_redirected_to primary_locations_url
  end
end
