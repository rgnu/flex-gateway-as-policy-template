.PHONY: policy.%

policy.%.definition.publish: NAME?=$*
policy.%.definition.publish: command.exist.$(CURL)
	$(call ASSERT_EXISTS,$(ANYPOINT_URL),ANYPOINT_URL should be defined) \
	$(call ASSERT_EXISTS,$(TOKEN),TOKEN should be defined) \
	$(call ASSERT_EXISTS,$(ORG_ID),ORG_ID should be defined) \
	$(call ASSERT_EXISTS,$(NAME),NAME should be defined) \
	$(call ASSERT_EXISTS,$(VERSION),VERSION should be defined) \
	$(call LOG_INFO,Publising Policy Definition $(NAME)@$(VERSION))
	$(HTTP_POST) '$(ANYPOINT_URL)/exchange/api/v2/organizations/$(ORG_ID)/assets/$(ORG_ID)/$(NAME)/$(VERSION)' \
		-H 'Authorization: Bearer $(TOKEN)' \
		-H 'x-sync-publication: true' \
		-F 'name="$(NAME)"' \
		-F 'description="$(DESCRIPTION)"' \
		-F 'type="policy"' \
		-F 'files.schema.json=@"$(CURDIR)/resources/definition.json"' \
		-F 'files.metadata.yaml=@"$(CURDIR)/resources/definition.yaml"' \
	&& ($(call LOG_INFO,Policy Definition $(NAME)@$(VERSION) published)) \
	|| ($(call LOG_ERROR_AND_EXIT,Error publishing Policy Definition $(NAME)@$(VERSION)))

policy.%.implementation.publish: NAME?=$*
policy.%.implementation.publish: command.exist.$(CURL) policy.%.implementation.pre-publish
	$(call ASSERT_EXISTS,$(ANYPOINT_URL),ANYPOINT_URL should be defined) \
	$(call ASSERT_EXISTS,$(TOKEN),TOKEN should be defined) \
	$(call ASSERT_EXISTS,$(ORG_ID),ORG_ID should be defined) \
	$(call ASSERT_EXISTS,$(NAME),NAME should be defined) \
	$(call ASSERT_EXISTS,$(VERSION),VERSION should be defined) \
	$(call ASSERT_EXISTS,$(EXTENDS),EXTENDS should be defined) \
	$(call LOG_INFO,Publising Policy Implementation $(NAME)@$(VERSION))
	$(HTTP_POST) '$(ANYPOINT_URL)/exchange/api/v2/organizations/$(ORG_ID)/assets/$(ORG_ID)/$(NAME)/$(VERSION)' \
		-H 'Authorization: Bearer $(TOKEN)' \
		-H 'x-sync-publication: true' \
		-F 'name="$(NAME)"' \
		-F 'description="$(DESCRIPTION)"' \
		-F 'type="policy-implementation"' \
		-F "dependencies=$(ORG_ID):$(EXTENDS)" \
		-F 'files.binary.wasm=@"$(CURDIR)/build/release.wasm"' \
		-F 'files.metadata.yaml=@"$(CURDIR)/resources/implementation.yaml"' \
	&& ($(call LOG_INFO,Policy Implementation $(NAME)@$(VERSION) published)) \
	|| ($(call LOG_ERROR_AND_EXIT,Error publishing Policy Implementation $(NAME)@$(VERSION)))

policy.%.pre-publish:
	$(NOP)


policy.%.delete: NAME?=$*
policy.%.delete: command.exist.$(CURL) policy.%.pre-delete
	$(call ASSERT_EXISTS,$(ANYPOINT_URL),ANYPOINT_URL should be defined) \
	$(call ASSERT_EXISTS,$(TOKEN),TOKEN should be defined) \
	$(call ASSERT_EXISTS,$(ORG_ID),ORG_ID should be defined) \
	$(call ASSERT_EXISTS,$(NAME),NAME should be defined) \
	$(call ASSERT_EXISTS,$(VERSION),VERSION should be defined) \
	$(call LOG_INFO,Deleting Policy $(NAME)@$(VERSION))
	$(HTTP_DELETE) '$(ANYPOINT_URL)/exchange/api/v1/organizations/$(ORG_ID)/assets/$(ORG_ID)/$(NAME)/$(VERSION)' \
		-H 'x-delete-type: hard-delete' \
		-H 'Authorization: Bearer $(TOKEN)' \
	&& ($(call LOG_INFO,Policy $(NAME)@$(VERSION) deleted)) \
	|| ($(call LOG_ERROR_AND_EXIT,Error deleting Policy $(NAME)@$(VERSION)))

policy.%.pre-delete:
	$(call LOG_INFO,Pre Delete Policy $(NAME)@$(VERSION))
