require 'spec_helper'

describe Project, :type => :model do
  let(:project) { build(:project) }
  let(:owned) { project }
  let(:not_owned) { build(:project, owner: nil) }
  let(:subject_relation) { create(:project_with_subjects) }
  let(:activatable) { project }
  let(:visible) { project }

  it_behaves_like "is ownable"
  it_behaves_like "has subject_count"
  it_behaves_like "activatable"
  it_behaves_like "has visibility controls"

  it "should have a valid factory" do
    expect(project).to be_valid
  end

  it "should require the primary language to be exactly 2 or 5 characters" do
    expect(build(:project, primary_language: 'a')).to_not be_valid
    expect(build(:project, primary_language: 'abasdf')).to_not be_valid
  end

  it "should require the primary languages to conform to a format" do
    expect(build(:project, primary_language: 'abasd')).to_not be_valid
    expect(build(:project, primary_language: 'ab')).to be_valid
    expect(build(:project, primary_language: 'ab-sd')).to be_valid
  end

  describe "#workflows" do
    let(:project) { create(:project_with_workflows) }

    it "should have many workflows" do
      expect(project.workflows).to all( be_a(Workflow) )
    end
  end

  describe "#subject_sets" do
    let(:project) { create(:project_with_subject_sets) }

    it "should have many subject_sets" do
      expect(project.subject_sets).to all( be_a(SubjectSet) )
    end
  end

  describe "#classifications" do
    let(:relation_instance) { project }

    it_behaves_like "it has a classifications assocation"
  end

  describe "#classifcations_count" do
    let(:relation_instance) { project }

    it_behaves_like "it has a cached counter for classifications"
  end

  describe "#subjects" do
    let(:relation_instance) { project }

    it_behaves_like "it has a subjects association"
  end

  describe "#content_for" do
    let(:project) { create(:project_with_contents) }

    it "should return the contents for the given language" do
      expect(project.content_for('en')).to be_a(ProjectContent)
    end
  end

  describe "#available_languages" do
    let(:project) { create(:project_with_contents) }

    it "should return a list of available languages" do
      expect(project.available_languages).to include('en')
    end
  end
end
