@Library('dst-shared@master') _
rpmBuild (
    githubPushRepo: "Cray-HPE/dracut-metal-dmk8s",
    githubPushBranches : "(release/.*|main)",
    specfile: "dracut-metal-dmk8s.spec",
    channel: "metal-ci-alerts",
    product: "csm",
    target_node: "ncn",
    fanout_params: ["sle15sp2"],
    slack_notify: ["", "", "false", "false", "true", "true"]
)
