FROM public.ecr.aws/everinvest/kubectl-eks:2.0

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
