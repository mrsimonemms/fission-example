# Copyright 2024 Simon Emms <simon@simonemms.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FISSION_CRDS ?= github.com/fission/fission/crds/v1
FISSION_NAMESPACE ?= fission
FISSION_REPO ?= https://fission.github.io/fission-charts

all: install-fission

cruft-update:
ifeq (,$(wildcard .cruft.json))
	@echo "Cruft not configured"
else
	@cruft check || cruft update --skip-apply-ask --refresh-private-variables
endif
.PHONY: cruft-update

install-fission:
	@echo "Installing CRDs..."
	@kubectl create -k ${FISSION_CRDS} || true

	@echo "Installing Fission..."
	@helm upgrade \
		--atomic \
		--cleanup-on-fail \
		--create-namespace \
		--install \
		--namespace ${FISSION_NAMESPACE} \
		--repo ${FISSION_REPO} \
		--reset-values \
		--set serviceType=NodePort,routerServiceType=NodePort \
		--wait \
		fission fission-all

	@echo "Verifying Fission..."
	@fission version

	@echo "Checking Fission..."
	@fission check
.PHONY: install-fission
