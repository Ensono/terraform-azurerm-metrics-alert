test_prereq: 
	mkdir -p .coverage
	go install github.com/jstemmer/go-junit-report/v2@latest && \
	go install github.com/axw/gocov/gocov@latest && \
	go install github.com/AlekSi/gocov-xml@latest

test: test_prereq
	cd test && go test ./... -v -buildvcs=false -mod=readonly -coverprofile=../.coverage/out -timeout=60m0s | go-junit-report > ../.coverage/report-junit.xml
