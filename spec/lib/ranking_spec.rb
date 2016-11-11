RSpec.describe Ranking do
  describe "#commit_activity_score" do
    it "returns zero if there is no gem_git" do
      laser_gem = LaserGem.create(name: "letmein")
      expect(Ranking.new(laser_gem).commit_activity_score).to be 0
    end

    it "ranks activity score 1 if latest commit was over a year ago" do
      laser_gem = LaserGem.create(name: "letmein")
      create :gem_git, 
        commit_dates_month: [2.years.ago, 3.years.ago], 
        laser_gem: laser_gem
      expect(Ranking.new(laser_gem).commit_activity_score).to be 1.0
    end
  end

  describe "#recent_activity_score" do
    it "returns zero if there is no gem_git" do
      laser_gem = LaserGem.create(name: "letmein")
      expect(Ranking.new(laser_gem).recent_activity_score).to be 0
    end

    it "ranks recent activity score 5 if latest commit was less than a week ago" do
      laser_gem = LaserGem.create(name: "rails")
      create :gem_git, 
        last_commit: 1.day.ago, 
        laser_gem: laser_gem
      expect(Ranking.new(laser_gem).recent_activity_score).to be 5.0
    end
  end

  describe "#forks_score" do
    it "returns zero if there is no gem_git" do
      laser_gem = LaserGem.create(name: "letmein")
      expect(Ranking.new(laser_gem).forks_score).to be 0
    end

    it "ranks forks score 3 if fork count is more than 50 but less than 500" do
      laser_gem = LaserGem.create(name: "rails")
      create :gem_git, 
        forks_count: 100,
        laser_gem: laser_gem
      expect(Ranking.new(laser_gem).forks_score).to be 3.0
    end
  end

  describe "#stargazers_score" do
    it "returns zero if there is no gem_git" do
      laser_gem = LaserGem.create(name: "letmein")
      expect(Ranking.new(laser_gem).stargazers_score).to be 0
    end

    it "ranks stargazer score 3 if stargazer_count is more than 50 but less than 500" do
      laser_gem = LaserGem.create(name: "rails")
      create :gem_git, 
        stargazers_count: 100,
        laser_gem: laser_gem
      expect(Ranking.new(laser_gem).stargazers_score).to be 3.0
    end
  end

  describe "#watchers_score" do
    it "returns zero if there is no gem_git" do
      laser_gem = LaserGem.create(name: "letmein")
      expect(Ranking.new(laser_gem).watchers_score).to be 0
    end

    it "ranks watchers score 1 if watchers_count is less than 1" do
      laser_gem = LaserGem.create(name: "rails")
      create :gem_git, 
        watchers_count: 0,
        laser_gem: laser_gem
      expect(Ranking.new(laser_gem).watchers_score).to be 1.0
    end
  end

  describe "#dependent_gems_score" do
    it "returns zero if there is no gem_spec" do
      laser_gem = LaserGem.create(name: "letmein")
      expect(Ranking.new(laser_gem).dependent_gems_score).to be 0
    end

    it "ranks dependent_gems_score  1 if number of dep. gems is less than 8" do
      laser_gem = create :laser_gem_with_dependents
      expect(Ranking.new(laser_gem).dependent_gems_score).to be 1.0
    end

    it "ranks dependent_gems_score  2 if number of dep. gems is more than 8 less than 80" do
      laser_gem = LaserGem.create(name: "letmein")
      create :gem_spec, 
        total_downloads: 1000000001,
        laser_gem: laser_gem
      # create_list :gem_dependency, 9, laser_gem: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      expect(Ranking.new(laser_gem).dependent_gems_score).to be 2.0
    end
  end


  describe "#total_downloads_score" do
    it "returns zero if there is no gem_spec" do
      laser_gem = LaserGem.create(name: "letmein")
      expect(Ranking.new(laser_gem).total_downloads_score).to be 0
    end

    it "ranks total_downloads_score  5 if number of downloads is more than 10000000" do
      laser_gem1 = LaserGem.create(name: "gem1")
      create :gem_spec, 
        total_downloads: 1000000001,
        laser_gem: laser_gem1
      expect(Ranking.new(laser_gem1).total_downloads_score).to be 5.0
    end

    it "ranks total_downloads_score  2 if number of downloads is more than 1000000 less than 3000000" do
      laser_gem1 = LaserGem.create(name: "gem1")
      create :gem_spec, 
        total_downloads: 2000001,
        laser_gem: laser_gem1
      expect(Ranking.new(laser_gem1).total_downloads_score).to be 2.0
    end
  end
  
  describe "#current_downloads_score" do
    it "returns zero if there is no gem_spec" do
      laser_gem = LaserGem.create(name: "letmein")
      expect(Ranking.new(laser_gem).current_downloads_score).to be 0
    end

    it "ranks current_downloads_score  5 if number of downloads is more than 500000" do
      laser_gem1 = LaserGem.create(name: "gem1")
      create :gem_spec, 
        current_version_downloads: 200000000,
        laser_gem: laser_gem1
      expect(Ranking.new(laser_gem1).current_downloads_score).to be 5.0
    end
  end

  describe "#download_rank" do
    it "returns number of downloads out total downloads" do
      laser_gem1 = LaserGem.create(name: "gem1")
      create :gem_spec, 
        total_downloads: 10,
        laser_gem: laser_gem1
      laser_gem2 = LaserGem.create(name: "gem2")
      create :gem_spec, 
        total_downloads: 30,
        laser_gem: laser_gem2
      laser_gem3 = LaserGem.create(name: "gem4")
      create :gem_spec, 
        total_downloads: 3000,
        laser_gem: laser_gem3
      laser_gem = LaserGem.create(name: "rails")
      create :gem_spec, 
        total_downloads: 400,
        laser_gem: laser_gem
      expect(Ranking.new(laser_gem).download_rank).to eq "2nd most downloaded gem of 4 gems"
    end
  end

  describe "#total_rank" do
    it "returns a float ranking for laser_gem" do
      laser_gem = LaserGem.create(name: "letmein")
      create :gem_spec, 
        total_downloads: 1000000001,
        current_version_downloads: 200000000,
        laser_gem: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_git,
        laser_gem: laser_gem,
        last_commit: 1.day.ago,
        forks_count: 5001,
        stargazers_count: 5001,
        watchers_count: 1001
      rank = Ranking.new(laser_gem).total_rank(laser_gem)
      expect(rank).to eq 0.7586206896551724
    end

    it "returns a float even if no gem_git" do
      laser_gem = LaserGem.create(name: "letmein")
      create :gem_spec, 
        total_downloads: 1000000001,
        current_version_downloads: 200000000,
        laser_gem: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      create :gem_dependency, dependency: laser_gem
      rank = Ranking.new(laser_gem).total_rank(laser_gem)
      expect(rank).to eq 0.8
    end
  end
end
