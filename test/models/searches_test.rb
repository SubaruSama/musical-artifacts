require 'test_helper'

class SearchesTest < ActiveSupport::TestCase
  setup do
    @artifacts = [
      FactoryGirl.create(:artifact,
        name: 'Sounfont file',
        description: 'An artifact for a soundfont file',
        author: 'Smarmy',
        license: FactoryGirl.create(:license, short_name: 'by'),
        file_format_list: ['sf2'],
        tag_list: ['soundfont', 'samples'],
        software_list: ['fluidsynth', 'saffronse', 'timidity']
      ),
      FactoryGirl.create(:artifact,
        name: 'Guitar file',
        description: 'An artifact with a guitar related file',
        author: 'Ziggy',
        license: FactoryGirl.create(:license, short_name: 'public'),
        file_format_list: ['gx'],
        tag_list: ['guitar', 'preset', 'tone'],
        software_list: ['guitarix']
      ),
      FactoryGirl.create(:artifact,
        name: 'Zip file',
        description: 'An artifact with content compressed in a zip file',
        author: 'Zippy',
        license: FactoryGirl.create(:license, short_name: 'copyright'),
        file_format_list: ['zip'],
        tag_list: ['compressed', 'samples']
      ),
      FactoryGirl.create(:artifact,
        name: 'Drum package',
        description: 'An artifact of a drumkit, with drum samples',
        author: 'Drumbrum',
        license: FactoryGirl.create(:license, short_name: 'by-sa'),
        file_format_list: ['rar'],
        tag_list: ['drums', 'drumkit', 'samples'],
        software_list: ['hydrogen']
      ),
      FactoryGirl.create(:artifact,
        name: 'A synth sound preset',
        description: 'An artifact with synth sound presets',
        author: 'Moogaloog',
        license: FactoryGirl.create(:license, short_name: 'copyright'),
        file_format_list: ['xmz'],
        tag_list: ['synth', 'preset'],
        software_list: ['zynaddsubfx', 'timidity']
      )]

    @scope = Artifact.all
  end

  test "#artifacts_by_metadata" do
    skip
  end

  test "#artifacts_tagged_with (none found)" do
    search = Searches::artifacts_tagged_with(@scope, 'thatshowthenewsgoes')

    assert_equal search.count, 0
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_tagged_with (one tag)" do
    search = Searches::artifacts_tagged_with(@scope, 'guitar')

    assert_equal search.count, 1
    assert_includes search, @artifacts[1]
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_tagged_with (one tag, two found)" do
    search = Searches::artifacts_tagged_with(@scope, 'preset')

    assert_equal search.count, 2
    assert_includes search, @artifacts[1]
    assert_includes search, @artifacts[4]
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_tagged_with (two tags)" do
    search = Searches::artifacts_tagged_with(@scope, 'synth, preset')

    assert_equal search.count, 1
    assert_includes search, @artifacts[4]
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_app_tagged_with (none found)" do
    search = Searches::artifacts_app_tagged_with(@scope, 'grassisbadah')

    assert_equal search.count, 0
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_app_tagged_with (one tag)" do
    search = Searches::artifacts_app_tagged_with(@scope, 'guitarix')

    assert_equal search.count, 1
    assert_includes search, @artifacts[1]
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_app_tagged_with (one tag) two found" do
    search = Searches::artifacts_app_tagged_with(@scope, 'timidity')

    assert_equal search.count, 2
    assert_includes search, @artifacts[0]
    assert_includes search, @artifacts[4]
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_app_tagged_with (two tags) exclusive" do
    search = Searches::artifacts_app_tagged_with(@scope, 'saffronse, zynaddsubfx')

    assert_equal search.count, 0
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_app_tagged_with (two tags, one found) exclusive" do
    search = Searches::artifacts_app_tagged_with(@scope, 'saffronse, fluidsynth')

    assert_equal search.count, 1
    assert_includes search, @artifacts[0]
  end

  test "#artifacts_licensed_as (none found)" do
    search = Searches::artifacts_licensed_as(@scope, 'wubalubadubadub')

    assert search.count, 0
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_licensed_as (copyright)" do
    search = Searches::artifacts_licensed_as(@scope, 'copyright')

    assert search.count, 2
    assert_includes search, @artifacts[2]
    assert_includes search, @artifacts[4]
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_licensed_as (public, by) inclusive" do
    search = Searches::artifacts_licensed_as(@scope, 'public, by')

    assert search.count, 2
    assert_includes search, @artifacts[0]
    assert_includes search, @artifacts[1]
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_with_file_format (none found)" do
    search = Searches::artifacts_with_file_format(@scope, 'exe')

    assert search.count, 0
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_with_file_format (zip)" do
    search = Searches::artifacts_with_file_format(@scope, 'zip')

    assert search.count, 1
    assert_includes search, @artifacts[2]
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_with_file_format (zip, rar) inclusive" do
    search = Searches::artifacts_with_file_format(@scope, 'zip, rar')

    assert_equal search.count, 2
    assert_includes search, @artifacts[2]
    assert_includes search, @artifacts[3]
    assert_kind_of ActiveRecord::Relation, search
  end

  test "#artifacts_with_hash (none found)" do
    search = Searches::artifacts_with_hash(@scope, '01011001')

    assert_equal search.count, 0
    assert_kind_of ActiveRecord::Relation, search
  end


  test "#artifacts_with_hash (one found)" do
    @artifacts[0].update_attributes(file_hash: '01011001')
    search = Searches::artifacts_with_hash(@scope, '01011001')

    assert_equal search.count, 1
    assert_includes search, @artifacts[0]
    assert_kind_of ActiveRecord::Relation, search
  end

  test "artifact searches with empty or nil params returns the same scope" do

    [:artifacts_with_hash, :artifacts_licensed_as, :artifacts_with_file_format,
     :artifacts_tagged_with, :artifacts_app_tagged_with, :artifacts_by_metadata].each do |method|
      assert_equal @scope, Searches.send(method, @scope, '')
      assert_equal @scope, Searches.send(method, @scope, nil)

      assert_equal Artifact.none, Searches.send(method, Artifact.none, '')
      assert_equal Artifact.none, Searches.send(method, Artifact.none, nil)
    end
  end

  test "#tags (list all)" do
  end

  test "#tags (find some)" do
  end

  test "#tags (find none)" do
  end

  test "#app_tags (list all)" do
    skip
  end

  test "#app_tags (find some)" do
    skip
  end

  test "#app_tags (find none)" do
    skip
  end

  test "#recent_tags" do
    skip
  end

end