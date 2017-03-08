module ApplicationHelper
    def score_percent
        score_correct.to_f / score_total * 100
    end

    def score_correct
        session[:stats]['cheese'][0] + session[:stats]['font'][0]
    end

    def score_incorrect
        session[:stats]['cheese'][1] + session[:stats]['font'][1]
    end

    def score_total
        score_correct + score_incorrect
    end
end
