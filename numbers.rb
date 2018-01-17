class Number
    def self.apartment
        return rand(1..100).to_s + ([true, false].sample ? ('a'..'h').to_a.sample : "")
    end

    def self.building
        return rand(1..200).to_s
    end

    def self.student_id
        return ('A'..'Z').to_a.sample(3).join("") + rand(100000..999999).to_s
    end

    def self.time_rand from = 0.0, to = Time.now
        Time.at(from + rand * (to.to_f - from.to_f))
    end      

end

