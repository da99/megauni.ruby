worker_processes 2

# listen '/home/da01/Documents/unicorn/the_stable.sock'

# :tcp_nodelay has no effect on UNIX sockets.
# :tcp_nopush has no effect on UNIX sockets. It is not needed or recommended.


# Combine Ruby Enterprise Edition (REE) with "preload_app true" 
# for memory savings.
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
# 
# However, I don't trust any type of preloading at this
# stage of the stack.
preload_app false 

# Are we using REE? Yes? 
# Then let's use it's garbage collecting features.
# GC.respond_to?(:copy_on_write_friendly=) and
    # GC.copy_on_write_friendly = true


# 
# after_fork do |server,worker|
# 
#    # from: ~/rubyee-gems/unicorn-0.93.3/doc/index.html
#    # drop permissions to "www-data" in the worker
#    # generally there's no reason to start Unicorn as a priviledged user
#    # as it is not recommended to expose Unicorn to public clients.
#    uid, gid = Process.euid, Process.egid
#    user, group = 'www-data', 'www-data'
#    target_uid = Etc.getpwnam(user).uid
#    target_gid = Etc.getgrnam(group).gid
#    worker.tmp.chown(target_uid, target_gid)
#    if uid != target_uid || gid != target_gid
#      Process.initgroups(user, target_gid)
#      Process::GID.change_privilege(target_gid)
#      Process::UID.change_privilege(target_uid)
#    end
# 
# end
