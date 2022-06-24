describe('counter_api_test', () => {
    it('GET', () => {
        cy.request('GET', 'https://ak2nkurklj.execute-api.us-east-1.amazonaws.com/prod/count').then((response) => {
            expect(response).to.have.property('status', 200)
            expect(response.body).to.not.be.null
            expect(response.body).to.be.a('number')
            expect(response).to.have.property('headers')
            expect(response).to.have.property('duration')

        })        
    })
})