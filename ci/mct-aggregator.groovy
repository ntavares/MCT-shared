import hudson.model.StringParameterValue
import com.cloudbees.plugins.credentials.CredentialsParameterValue
import com.cloudbees.plugins.credentials.CredentialsProvider
import com.cloudbees.plugins.credentials.common.StandardUsernameCredentials

def mctCheckoutParameters = [
  new StringParameterValue('git_repo_url', 'https://github.com/schubergphilis/MCCloud', 'Git repository URL'),
  new StringParameterValue('sha1', 'tmp/combined-prs-496-497-498', 'Git branch'),
  new CredentialsParameterValue('git_repo_credentials', '298a5b23-7bfc-4b68-82aa-ca44465b157d', 'Git repo credentials')
]

def checkoutJobBuild = build job: 'mccloud/mct-checkout', parameters: mctCheckoutParameters

print "==> Chekout Job Id       = ${checkoutJobBuild.getId()}"
print "==> Chekout Job Name     = ${checkoutJobBuild.getName()}"
print "==> Chekout Build Number = ${checkoutJobBuild.getNumber()}"

def checkoutJobName        = checkoutJobBuild.getName()
def checkoutJobBuildNumber = checkoutJobBuild.getNumber()

def mctDeployInfraParameters =[
  new StringParameterValue('parent_job', checkoutJobName, 'Parent Job Name'),
  new StringParameterValue('parent_job_build', checkoutJobBuildNumber, 'Parent Job Build Number'),
  new StringParameterValue('hypervisor_hosts', 'kvm1 kvm2', 'Hypervisor Hosts'),
  new StringParameterValue('secondary_storage_location', '/data/storage/secondary/MCCT-SHARED-1', 'Secondary Storage Location'),
  new StringParameterValue('marvin_config_file', 'mct-zone1-kvm1-kvm2.cfg', 'Marvin Configuration File')
]

def deployInfraJobBuild = build job: 'mccloud/mct-deploy-infra', parameters: mctDeployInfraParameters

print "==> Deploy Infra Job Id        = ${deployInfraJobBuild.getId()}"
print "==> Deploy Infra  Job Name     = ${deployInfraJobBuild.getName()}"
print "==> Deploy Infra  Build Number = ${deployInfraJobBuild.getNumber()}"

//def credentials = findCredentials({ c -> c.id  == '298a5b23-7bfc-4b68-82aa-ca44465b157d' })
def findCredentials(matcher) {
  def creds = CredentialsProvider.lookupCredentials(StandardUsernameCredentials.class)
  for (c in creds) {
      if(matcher(c)) {
        return c
      }
  }
  return null
}
