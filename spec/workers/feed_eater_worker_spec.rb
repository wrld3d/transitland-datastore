describe FeedEaterWorker do
  it 'should pull the latest Transitland Feed Registry' do
    allow(TransitlandClient::FeedRegistry).to receive(:repo) { true }
    worker = FeedEaterWorker.new
    allow(worker).to receive(:run_python_and_return_stdout) { '' } # skip system calls to Python code
    worker.perform
    expect(TransitlandClient::FeedRegistry).to have_received(:repo)
  end
end
