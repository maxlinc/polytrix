# -*- encoding: utf-8 -*-

Polytrix.validate 'Bootstraps java and ruby, but not python', suite: 'CLI', scenario: 'bootstrap' do |challenge|
  expect(challenge.result.stdout).to include('-----> Bootstrapping java')
  expect(challenge.result.stdout).to include('-----> Bootstrapping ruby')
  expect(challenge.result.stdout).to_not include('-----> Bootstrapping python')
end
