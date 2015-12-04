import hudson.model.*;
import jenkins.model.*;

println "--> disabling master executors"
Jenkins.instance.setNumExecutors(0)
Jenkins.instance.setLabelString()
println "--> disabling master executors...done"
