import hudson.model.*
import jenkins.model.*

import java.util.concurrent.TimeUnit

Thread.start {
    sleep 15000

    println "--> installing/updating plugins (with dependencies)"
    [
            'cloudbees-folder',
            'docker-commons',
    ].each { pluginId ->
        try {
            def plugin = Jenkins.instance.getUpdateCenter().getPlugin(pluginId)
            if (!plugin.installed) {
                plugin.deploy(true).get(5, TimeUnit.MINUTES)
            }
        } catch (Exception x) {
            x.printStackTrace()
        }
    }
    println "--> installing/updating plugins (with dependencies)...done"
}