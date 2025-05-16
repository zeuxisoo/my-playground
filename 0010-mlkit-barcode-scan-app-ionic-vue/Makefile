all:
	@echo "Command       : Description"
	@echo "------------- : -----------"
	@echo "make ios      : Install iOS development"
	@echo "make server   : Start the development server"
	@echo "make build-ios: Build the production dist directory"

ios:
	@yarn global add ios-sim
	@brew install ios-deploy
	@ionic capacitor add ios

server:
	@ionic serve

build:
	@ionic build --prod

build-ios:
	@cd ios/App && pod deintegrate && rm -rf Podfile.lock && cd -
	@ionic capacitor copy ios
	@ionic capacitor update

ios-xcode:
	@ionic capacitor open ios

copy-ios:
	@ionic capacitor copy ios
