.DEFAULT_GOAL=help
.PHONY=help show diff apply delete update image

help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

show: ## Show output of rendered templates
	kubectl get hr -n $(NAMESPACE) $(NAME) -o jsonpath='{.spec.values}' | helm template --dry-run=server -n $(NAMESPACE) $(NAME) . -f -

apply: suspend ## Apply Helm release to a Kubernetes cluster 
	kubectl get hr -n $(NAMESPACE) $(NAME) -o jsonpath='{.spec.values}' | helm upgrade -i -n $(NAMESPACE) $(NAME) . -f -

diff: ## Diff Helm release against objects in a Kubernetes cluster
	kubectl get hr -n $(NAMESPACE) $(NAME) -o jsonpath='{.spec.values}' | helm diff upgrade --allow-unreleased --normalize-manifests -n $(NAMESPACE) $(NAME) . -f -

suspend: ## Suspend reconciliation for an existing Helm release
	kubectl patch hr -n $(NAMESPACE) $(NAME) -p '{"spec": {"suspend": true}}' --type=merge --field-manager=flux-client-side-apply

resume: ## Resume reconciliation for an existing Helm release
	kubectl patch hr -n $(NAMESPACE) $(NAME) -p '{"spec": {"suspend": null}}' --type=merge --field-manager=flux-client-side-apply
