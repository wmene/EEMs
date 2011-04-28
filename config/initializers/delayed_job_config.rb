require 'delayed_job'

Delayed::Worker.max_attempts = 4
Delayed::Worker.max_run_time = 5.minutes
