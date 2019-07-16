#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright (c) 2019, Agenzia per l'Italia Digitale

import argparse
import sys
import re

from python_terraform import *
from datetime import datetime
from termcolor import colored, cprint

LOGFILE = 'wai-provisioner.log'
DEFAULT_RESOURCES = ['openstack_compute_keypair_v2', 'openstack_networking_router_v2']

def terraform_exec(terraform, command, *arguments, **options):
    """
    Perform a terraform command and logs its output
    """
    return_code, stdout, stderr = terraform.cmd(command, *arguments, **options, no_color=IsFlagged)
    with open(LOGFILE, 'a') as logfile:
        logfile.write(str(datetime.now()) + ' - ' + 'execution of terraform ' + command)
        if arguments:
            logfile.write('\narguments: ' + (', ').join(arguments) + '\n')
        if options:
            logfile.write('\noptions:\n')
            for key, value in options.items():
                logfile.write("   {0}={1}".format(key, value))
        logfile.write('\n========== start of terraform output ==========\n')
        logfile.write(stdout)
        logfile.write(stderr)
        logfile.write('=========== end of terraform output ===========\n')
        logfile.write(str(datetime.now()) + ' - ' + 'execution finished with return code ' + str(return_code) + '\n\n')
    if return_code != 0:
        cprint('[✘]', 'red', attrs=['bold'], end='', file=sys.stderr)
        cprint('[workspace: ' + terraform_current_workspace(terraform) + ']', 'yellow', attrs=['bold'], end=' ', file=sys.stderr)
        cprint('terraform ' + command + ' ' + (' ').join(arguments), attrs=['bold'], file=sys.stderr)
        raise Exception('Something went wrong during the execution of terraform ' + command)

    cprint('[✔]', 'green', attrs=['bold'], end='')
    cprint('[workspace: ' + terraform_current_workspace(terraform) + ']', 'yellow', attrs=['bold'], end=' ')
    cprint('terraform ' + command + ' ' + (' ').join(arguments), attrs=['bold'])

def terraform_workspace_exists(terraform, workspace):
    """
    Check if a given terraform workspace exists
    """
    return_code, stdout, stderr = terraform.cmd('workspace list')
    workspaces = list(filter(None, [re.sub('[\s+\*]', '', ws) for ws in stdout.split('\n')]))
    return workspace in workspaces

def terraform_current_workspace(terraform):
    """
    Get the current terraform workspace
    """
    return_code, stdout, stderr = terraform.cmd('workspace show')
    return stdout.rstrip()

def terraform_default_applied(terraform):
    """
    Check if the resources in the default workspace have already been created
    """
    terraform.cmd('workspace select', 'default')
    return_code, stdout, stderr = terraform.cmd('state list')
    resources = list(filter(None, [re.sub('\.\S+$', '', res) for res in stdout.split('\n')]))
    return all(i in resources for i in DEFAULT_RESOURCES)

def user_confirms(confirmation_text):
    """
    Ask user to confirm with y or n (case-insensitive).
    """
    answer = ''
    while answer not in ['y', 'n']:
        answer = input(colored(confirmation_text + ' ', 'blue', attrs=['bold'])).lower()
    return answer == 'y'

def parse_args():
    parser = argparse.ArgumentParser(description='WAI privisioner')
    parser.add_argument('environment', choices=['production', 'staging', 'public-playground'],
                        help='the environment to create or destroy')
    parser.add_argument('action', choices=['apply', 'destroy'],
                        help='the action to take on the environment')
    parser.add_argument('--dry-run', action='store_true',
                        help='simulate the chosen action')

    return parser.parse_args()


def main():
    args = parse_args()
    terraform_basedir = os.path.dirname(os.path.realpath(__file__))
    t = Terraform(working_dir=terraform_basedir, parallelism=1)
    tfvars = [
        os.path.join(terraform_basedir, 'env-common.tfvars'),
    ]

    try:
        terraform_exec(t, 'init', backend_config='backend-config')

        if not terraform_default_applied(t):
            if user_confirms('Default resources [keypair, external router] must be created before proceeding. Confirm [y/n]?'):
                terraform_exec(t, 'plan', var_file=tfvars)
                terraform_exec(t, 'apply', var_file=tfvars, auto_approve=IsFlagged)
            else:
                cprint('Operation cancelled by the user.', 'red', attrs=['bold'])
                sys.exit(0)

        if not terraform_workspace_exists(t, args.environment):
            terraform_exec(t, 'workspace new', args.environment)
        
        terraform_exec(t, 'workspace select', args.environment)

        tfvars.append(os.path.join(terraform_basedir, 'env-' + args.environment + '.tfvars'))

        if args.action == 'apply':
            terraform_exec(t, 'plan', var_file=tfvars)
            if not args.dry_run and user_confirms('Confirm resources creation [y/n]?'):
                cprint('This can take a while...', 'blue', attrs=['bold'])
                terraform_exec(t, 'apply', var_file=tfvars, auto_approve=IsFlagged)
            else:
                cprint('Operation cancelled by the user.', 'red', attrs=['bold'])
        else:
            terraform_exec(t, 'plan', var_file=tfvars, destroy=IsFlagged)
            if not args.dry_run and user_confirms('Confirm resources destruction (cannot be undone) [y/n]?'):
                cprint('This can take a while...', 'blue', attrs=['bold'])
                terraform_exec(t, 'destroy', var_file=tfvars, auto_approve=IsFlagged)
            else:
                cprint('Operation cancelled by the user.', 'red', attrs=['bold'])

        terraform_exec(t, 'workspace select', 'default')
    except Exception as e:
        cprint(str(e) + '\n', 'red', attrs=['bold'], end='', file=sys.stderr)
        cprint('Check ' + LOGFILE + ' file for details\n', 'red', attrs=['bold'], end='', file=sys.stderr)
        sys.exit(1)
    sys.exit(0)


if __name__ == '__main__':
    main()
